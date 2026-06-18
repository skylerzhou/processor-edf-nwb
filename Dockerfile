FROM ghcr.io/catalystneuro/neuroconv:v0.6.1

RUN apt-get update && apt-get install -y gettext

WORKDIR /app

# Pennsieve runs the container as a non-root user that cannot write to /app or
# the default HOME (/). Point HOME and the cache at /tmp so library imports
# (dandi -> fscacher -> joblib) and the generated config can be written.
ENV HOME=/tmp \
    XDG_CACHE_HOME=/tmp/.cache

COPY neuroconv_edf.template.yml /app/neuroconv_edf.template.yml

COPY --chmod=755 entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
