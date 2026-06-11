# A minimal reproducible scientific workflow template in R using Positron, renv, brms/CmdStan, Quarto, and Docker

This repository is a minimal, worked example of a reproducible scientific workflow in R — from data wrangling and Bayesian modelling to manuscript rendering — using Positron, renv, brms/CmdStan, Quarto, and Docker. 
It is intended as a teaching resource and template for researchers who want a complete open science stack without unnecessary complexity.

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
├── model.qmd            # Model fitting and diagnostics
├── quarto-template/     # Example manuscript using quarto-preprint
├── data.csv             # Simulated data
├── renv.lock            # Locked R package versions
├── .Rprofile            # renv activation
├── Dockerfile           # Docker image specification
├── docker-compose.yml   # Docker container configuration
├── renv/                # renv project library (auto-generated)
├── air.toml             # Air code formatter settings
└── .vscode/             # Positron workspace settings

```

## Reproducing this project

There are two ways to reproduce this project, depending on your setup and goals.

### Option 1 — Local (R users)

Requires R 4.6.0, Positron (or RStudio), and CmdStan installed locally.

```bash
git clone https://github.com/rich-ramsey/positron-test.git
cd positron-test
```

Open the folder in Positron.
renv will activate automatically and prompt you to restore packages:

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

**Fun fact**: I expect `renv` will not work straight away or as expected. 
See this [video](https://www.youtube.com/watch?v=l01u7Ue9pIQ) for more on why.
And that's why Docker becomes more important - see next section (Option 2).

### Option 2 — Interactive Docker container (recommended)

Requires [Docker Desktop](https://www.docker.com/products/docker-desktop).

This option provides a fully reproducible environment with R 4.6.0, all packages, and CmdStan 2.39.0 pre-installed.
No local R installation required.
It is the recommended approach for reproducibility verification, teaching, and collaboration.

Scripts are run manually inside RStudio Server in the browser, in the same order as Option 1.

To start the container, there are two options:

**Option 2a — Use the pre-built image from Docker Hub (quickest)**

The `docker-compose.yml` file uses the pre-built image by default.
No build required — Docker will pull the image automatically on first run.

```bash
git clone https://github.com/rich-ramsey/positron-test.git
cd positron-test
docker compose up -d
```

**Option 2b — Build the image yourself**

If you prefer to build the image from the Dockerfile, edit `docker-compose.yml` by commenting out the `image:` line and uncommenting the `build:` line.
The first build takes approximately 20-30 minutes (installing packages and compiling CmdStan).

```bash
git clone https://github.com/rich-ramsey/positron-test.git
cd positron-test
docker compose up -d
```

**Accessing RStudio Server**

Once the container is running, open [http://localhost:8787](http://localhost:8787) in your browser.
RStudio Server will open with all packages and CmdStan pre-installed.
This can take a few minutes to load, especially on Apple Silicon Macs, since the container runs in amd64 emulation mode.

Then run scripts in order:
1. `wrangle.qmd` — simulate data and create plots
2. `model.qmd` — fit a model
3. `quarto-template/quarto-template.qmd` — render an example manuscript

To stop the container:

```bash
docker compose down
```

**Note on RStudio sessions**

If the browser shows an old R session, go to Session → Quit Session, then Session → New Session to start fresh.

**Troubleshooting errors**

If you get the error "CmdStan path not set" or there are packages missing: Go to Session → Quit Session → New Session in the browser to start a fresh R session. 
If problems persist, run:

```bash
docker compose down
docker compose pull
docker compose up -d 
```


This ensures that you have the latest image, then start a new session.

## Working with large files

For real projects, large files (raw data, fitted model objects) are stored on OSF rather than GitHub.
The following handles this automatically:

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

If you fit models both locally and inside the Docker container, the resulting model files may differ in size due to different compression behaviour between native and emulated (amd64) environments (I think!).
The model results (estimates, ESS, Rhat) will be identical — so compare summaries rather than file sizes.

The model fitting chunk in model.qmd is set to eval: true.
As this example is a simple model, it does not take very long.
For more complex models this may take a long time, hence why the default would typically be eval: false.

## General workflow

This repository demonstrates the following workflow:

1. **Develop locally** in Positron with renv and git
2. **Store large files** on OSF with auto-download in scripts
3. **At submission**, build Docker image and push to Docker Hub
4. **At acceptance**, link GitHub to Zenodo for a citable DOI

## Feedback

This template is a first draft of something that *hopefully* works, but I very much welcome constructive feedback on ways that it can be improved.

## Citation

A Zenodo archive with a citable DOI may be created if I ever get to a first stable release.
In the meantime, please cite the GitHub repository:

> Ramsey, R. (2026). A minimal reproducible scientific workflow template in R using Positron, renv, brms/CmdStan, Quarto, and Docker.
> GitHub. https://github.com/rich-ramsey/positron-workflow

## Licence

This work is licensed under CC BY 4.0. <https://creativecommons.org/licenses/by/4.0/>

## Acknowledgments

Many thanks to Sven Panis and Matti Vuorre for helpful feedback on a previous version of this project.