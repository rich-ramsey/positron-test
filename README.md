# A minimal reproducible scientific workflow template for psychological and brain science research

This project presents a minimal reproducible workflow template for cognitive neuroscience research using Positron, R, Bayesian modelling, and Docker.
The repository is a worked example of a complete open science workflow — from data wrangling and model fitting to manuscript rendering and reproducible environments. 
It is intended as a teaching resource and template.

## Resources

This repository draws on the following excellent resources.

### Journal articles

These two journal articles are fantastic introductions to version control via git and the use of containers for reproducible research.
They are pitched at beginners, and they are clear and easy to follow. 
I strongly recommend reading both of them in detail before continuing further with this project.

- [Vuorre & Curley, 2018, Curating Research Assets: A Tutorial on the Git Version Control System](https://journals.sagepub.com/doi/10.1177/2515245918754826)

- [Wiebels & Moreau, 2021, Leveraging Containers for Reproducible Psychological Research](https://journals.sagepub.com/doi/10.1177/25152459211017853)


### Blogs and webpages

- [Andrew Heiss — Docker and RStudio](https://www.andrewheiss.com/blog/2017/04/27/super-basic-practical-guide-to-docker-and-rstudio/)
- [Andrew Heiss — Positron + SSH + Docker](https://www.andrewheiss.com/blog/2025/07/05/positron-ssh-docker/)
- [Matti Vuorre — Reproducible scientific workflows](https://vuorre.com/posts/workflow/)
- [Matti Vuorre — quarto-preprint](https://github.com/mvuorre/quarto-preprint)
- [renv documentation](https://rstudio.github.io/renv/)
- [cmdstanr documentation](https://mc-stan.org/cmdstanr/)
- [Rocker project](https://rocker-project.org)
- [The Turing Way — Reproducible Research](https://the-turing-way.netlify.app/reproducible-research/reproducible-research.html)

## Stack

- **IDE**: [Positron](https://positron.posit.co) (VS Code-based, R/Python)
- **Language**: [R](https://www.r-project.org/)
- **Data wrangling and visualisation**: [Tidyverse](https://tidyverse.org/)
- **Modelling**: [brms](https://paul-buerkner.github.io/brms/) + [cmdstanr](https://mc-stan.org/cmdstanr/) + [CmdStan](https://mc-stan.org/docs/cmdstan-guide/)
- **Package management**: [renv](https://rstudio.github.io/renv/)
- **Manuscript**: [Quarto](https://quarto.org) + [quarto-preprint](https://github.com/mvuorre/quarto-preprint) (Typst PDF + HTML)
- **Reproducible environment**: [Docker](https://www.docker.com) + [rocker](https://rocker-project.org)
- **Data and model storage**: [OSF](https://osf.io) (for large files)
- **Permanent archive**: [Zenodo](https://zenodo.org) (DOI on journal acceptance)

## Project structure

```
positron-test/
├── wrangle.qmd          # Data wrangling and visualisation
├── model.qmd            # Model fitting (eval: false) and diagnostics
├── quarto-template/     # Example manuscript using quarto-preprint
├── b1.rds               # Reference model object (fitted locally)
├── data.csv             # Simulated data
├── dat_plot.png         # Example plot
├── renv.lock            # Locked R package versions
├── .Rprofile            # renv activation
├── Dockerfile           # Docker image specification
├── docker-compose.yml   # Docker container configuration
├── air.toml             # Air code formatter settings
└── .vscode/             # Positron workspace settings
```

## Reproducing this project

### Option 1 — Local (R users)

Requires R, Positron (or RStudio), and CmdStan installed locally.

```bash
git clone https://github.com/rich-ramsey/positron-test.git
cd positron-test
```

Open the folder in Positron. renv will activate automatically and prompt you to restore packages:

```r
renv::restore()
```

Install CmdStan if not already installed:

```r
cmdstanr::install_cmdstan()
```

Then open and run scripts in order:
1. `wrangle.qmd` — simulate data and create plots
2. `model.qmd` — fit a model
3. `quarto-template/quarto-template.qmd` — render an example manuscript

### Option 2 — Docker (recommended for full reproducibility)

Requires [Docker Desktop](https://www.docker.com/products/docker-desktop).
There are two ways to access the Docker container.

**Option 2a. Use the pre-built docker image.**

The quickest way is to use the pre-built Docker image that is available on Docker Hub (no build required).
To do so, the `docker-compose.yml` file must have the image: argument as image: richramsey/positron-test:latest.
This is the default approach.

**Option 2b. Build the docker image.**

The longer way is to build the Docker image yourself from the Dockerfile.
To do so, the `docker-compose.yml` file must have the build: argument as build: .
The first build takes ~35 minutes (installing packages and compiling CmdStan). 
Subsequent starts are instant.
If you want to build the Docker image, then edit the `docker-compose.yml` file by commenting out the image: argument and including the build: argument.

To start the container:

```bash
git clone https://github.com/rich-ramsey/positron-test.git
cd positron-test
docker pull richramsey/positron-test:latest
docker compose up -d
```
Go to [http://localhost:8787](http://localhost:8787) in your browser. 
RStudio Server will open with all packages and CmdStan pre-installed.
This can take a few minutes.

To stop the container:

```bash
docker compose down
```

## Working with large files

For real projects, large files (raw data, fitted model objects) are stored on OSF rather than GitHub. The following pattern handles this automatically:

```r
# Download data from OSF if not already present locally
# if (!file.exists("data/exp1.csv")) {
#   download.file(
#     url = "https://osf.io/xxxxx/download",
#     destfile = "data/exp1.csv"
#   )
# }
# dat <- read_csv("data/exp1.csv")

# For this example, data are simulated directly
```

```r
# Download pre-fitted model from OSF if not already present locally
# if (!file.exists("models/b1.rds")) {
#   download.file(
#     url = "https://osf.io/yyyyy/download",
#     destfile = "models/b1.rds"
#   )
# }

# For this example, model object is included in the repo
b1 <- readRDS("b1.rds")
```

Files downloaded inside the container appear in your local folder via the volume mount, and vice versa — so you only ever download once.

## Notes on model objects

`b1.rds` was fitted locally on Apple Silicon (Mac Studio). 
If you refit the model in the Docker container (which runs in amd64 emulation), the resulting file will be larger due to different compression behaviour in the emulated environment (I think). 
The model results (estimates, ESS, Rhat) will be identical — compare summaries rather than file sizes.

The model building chunk in `model.qmd` is set to `eval: false`. 
To refit from scratch, set `eval: true`.
As this example is a simple model, it doesn't take very long.
But be aware that for more complex models, this may take a long time, hence why the default is set to `eval: false`.

## General workflow

This repository demonstrates the following workflow:

1. **Develop locally** in Positron with renv and git
2. **Store large files** on OSF with auto-download in scripts
3. **At submission**, build Docker image and push to Docker Hub from the GitHub repo
4. **At acceptance**, link GitHub to Zenodo for a citable DOI

## Citation

This repository is archived on Zenodo:

> Ramsey, R. (2026). A minimal reproducible scientific workflow template for psychological and brain science research. Zenodo. https://doi.org/10.5281/zenodo.xxxxxxx

*(DOI will be added on journal acceptance)*

## Licence

This work is licensed under CC BY 4.0.
https://creativecommons.org/licenses/by/4.0/