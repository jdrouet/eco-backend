FROM openjdk:18-jdk-slim AS builder

# Install server
WORKDIR /code
COPY .mvn /code/.mvn
COPY pom.xml /code/pom.xml
COPY mvnw /code/mvnw
RUN ./mvnw dependency:go-offline

COPY src /code/src
RUN ./mvnw install
RUN mkdir -p target/dependency
WORKDIR /code/target/dependency
RUN jar -xf ../*.jar

FROM openjdk:11-jre-slim

EXPOSE 8080
VOLUME /tmp
ARG DEPENDENCY=/code/target/dependency
COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","jd.eco.backend.BackendApplication"]

