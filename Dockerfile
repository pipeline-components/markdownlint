FROM ruby:2.7.1-alpine3.10 as build

WORKDIR /app/
COPY app /app/
RUN bundle install --frozen --deployment --binstubs=/app/bin/ --no-cache --standalone --clean --verbose
# Because --no-cache is broken https://github.com/bundler/bundler/issues/6680
RUN rm -rf  vendor/bundle/ruby/*/cache

# app image
FROM pipelinecomponents/base-entrypoint:0.2.0 as entrypoint

FROM ruby:2.7.1-alpine3.10
COPY --from=entrypoint /entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV DEFAULTCMD mdl

WORKDIR /app/
COPY --from=build /app/ /app/
ENV PATH "${PATH}:/app/bin/"

# Add git to support the mdl '--git-recurse' option
RUN apk add --no-cache git=2.22.2-r0

WORKDIR /code/
# Build arguments
ARG BUILD_DATE
ARG BUILD_REF

# Labels
LABEL \
    maintainer="Robbert Müller <spam.me@grols.ch>" \
    org.label-schema.description="Markdownlint in a container for gitlab-ci" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Markdownlint" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://pipeline-components.gitlab.io/" \
    org.label-schema.usage="https://gitlab.com/pipeline-components/markdownlint/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/pipeline-components/markdownlint/" \
    org.label-schema.vendor="Pipeline Components"
