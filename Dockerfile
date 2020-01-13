FROM scratch
ADD out/funnel /
ENV PORT 8090
EXPOSE 8090
ENTRYPOINT ["/funnel"]