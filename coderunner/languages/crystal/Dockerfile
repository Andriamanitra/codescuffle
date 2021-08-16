FROM crystallang/crystal:1.1.1-alpine
COPY build/runrequesthandler /bin/runreqhandler

ENV SCUFFLE_COMPILATION_COMMAND="crystal build --no-color -o %EXECUTABLE% %CODE%" \
    SCUFFLE_RUN_COMMAND="%EXECUTABLE%"
