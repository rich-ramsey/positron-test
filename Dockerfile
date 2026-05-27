FROM rocker/tidyverse:4.6.0

# Install system dependencies needed for Stan/CmdStan
RUN apt-get update && apt-get install -y \
    libv8-dev \
    cmake \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Quarto (rocker's bundled version is too old for quarto-preprint)
ARG QUARTO_VERSION=1.9.37
RUN curl -LO https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb && \
    dpkg -i quarto-${QUARTO_VERSION}-linux-amd64.deb && \
    rm quarto-${QUARTO_VERSION}-linux-amd64.deb

# Install renv to system library
RUN Rscript -e "install.packages('renv')"

# Set working directory
WORKDIR /home/rstudio

# Copy renv infrastructure and lockfile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile

# Set correct ownership
RUN chown -R rstudio:rstudio /home/rstudio

# Restore renv packages as rstudio user
# Disable cache so packages install directly without symlinks
RUN sudo -u rstudio Rscript -e "\
    Sys.setenv(RENV_CONFIG_CACHE_ENABLED = 'FALSE'); \
    options(repos = c( \
        stan = 'https://mc-stan.org/r-packages/', \
        CRAN = 'https://cran.r-project.org' \
    )); \
    renv::restore()"

# Install cmdstanr from correct r-universe source
# Bypasses renv to ensure correct version and source
RUN sudo -u rstudio Rscript -e "\
    Sys.setenv(RENV_CONFIG_CACHE_ENABLED = 'FALSE'); \
    install.packages('cmdstanr', \
        repos = c('https://stan-dev.r-universe.dev', getOption('repos')))"

# Install pinned CmdStan version as rstudio user
# Version pinned to match local environment - update when you update CmdStan locally
RUN sudo -u rstudio Rscript -e "\
    cmdstanr::install_cmdstan(version = '2.39.0', cores = 28)"

# Expose RStudio Server port
EXPOSE 8787