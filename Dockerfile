FROM arm32v7/ubuntu:20.04

RUN apt-get -qq update && \
    apt-get install -y gcc g++ make xz-utils wget vim libtinfo5 git python3 libgmp-dev libtinfo-dev zlib1g-dev locales haskell-platform

RUN wget --no-check-certificate "https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-armv7a-linux-gnueabihf.tar.xz" \
		&& wget "https://downloads.haskell.org/~ghc/8.10.4/ghc-8.10.4-armv7-deb10-linux.tar.xz" \
		&& tar xvf clang+llvm-9.0.1-armv7a-linux-gnueabihf.tar.xz \
		&& tar xvf ghc-8.10.4-armv7-deb10-linux.tar.xz

# Install clang
RUN cd clang+llvm-9.0.1-armv7a-linux-gnueabihf && mv bin/* /usr/local/bin/ && mv include/* /usr/local/include/ && mv lib/* /usr/local/lib/ && cd .. && rm clang+llvm-9.0.1-armv7a-linux-gnueabihf.tar.xz

# Install ghc
RUN cd ghc-8.10.4 && ./configure && make install && cd .. && rm -r ghc-8.10.4 && rm ghc-8.10.4-armv7-deb10-linux.tar.xz

# Run cabal update
RUN cabal update

# Build new version of cabal using old version of cabal
RUN cabal install --project-file=cabal.project.release --constraint="lukko -ofd-locking" cabal-install

# Get rid of extra stuff
RUN apt-get --purge autoremove -y haskell-platform && rm -rf /var/lib/apt/lists/*

# Add new cabal to path
ENV PATH="/root/.cabal/bin:${PATH}"
