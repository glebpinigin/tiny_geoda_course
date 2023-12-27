 
FROM alpine

ENV TZ=Europe/Moscow

RUN \
  apk add --no-cache gmp libffi zlib pcre pandoc R R-dev curl openssl-dev curl-dev gcc g++ git coreutils libxml2-dev \
  && \
  rm -rf /tmp/*

WORKDIR /opt/deploy_dir

COPY renv.lock renv ./

RUN \
  echo "MAKEFLAGS=-j$(nproc)" | tee ~/.Renviron \
  && \
  R -e "print(Sys.getenv('MAKEFLAGS'))" \
  && \
  R -e "install.packages('renv', repos='http://cran.rstudio.com/')" \
  && \
  R -e "renv::restore()" \
  && \
  R -e "renv::activate()" \
  && \
  echo "r environment ready"

COPY . .

RUN \
  R -e "renv::restore()" \
  && \
  R -e "renv::activate()" \
  && \
  R -e "bookdown::render_book()" \
  && \
  echo "book rendered"