FROM ruby:3.2.2-alpine3.17 as build

WORKDIR /app/
COPY app /app/
RUN \
    bundle config set --global clean 'true' && \
    bundle config set --global deployment 'true' && \
    bundle config set --global frozen 'true' && \
    bundle install --binstubs=/app/bin/ --standalone --verbose && \
# Because --no-cache is broken https://github.com/bundler/bundler/issues/6680
    rm -rf  bundle/ruby/*/cache

# app image
FROM pipelinecomponents/base-entrypoint:0.5.0 as entrypoint

FROM ruby:3.2.2-alpine3.17
COPY --from=entrypoint /entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV DEFAULTCMD mdl

WORKDIR /app/
COPY --from=build /app/ /app/
ENV PATH "${PATH}:/app/bin/"

# Add git to support the mdl '--git-recurse' option
# hadolint ignore=DL3018
RUN apk add --no-cache git

WORKDIR /code/
# Build arguments
ARG BUILD_DATE
ARG BUILD_REF

# Labels
LABEL \
    maintainer="Robbert Müller <dev@pipeline-components.dev>" \
    org.label-schema.description="Markdownlint in a container for gitlab-ci" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Markdownlint" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://pipeline-components.gitlab.io/" \
    org.label-schema.usage="https://gitlab.com/pipeline-components/markdownlint/blob/main/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/pipeline-components/markdownlint/" \
    org.label-schema.vendor="Pipeline Components"
