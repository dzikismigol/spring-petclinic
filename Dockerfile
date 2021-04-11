#syntax=docker/dockerfile:1.2
FROM openjdk:11-jdk-slim-buster AS builder

WORKDIR /app
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2 ./mvnw package -DskipTests
RUN java -Djarmode=layertools -jar target/*.jar extract

FROM openjdk:11-jre-slim-buster
WORKDIR /app

COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/application/ ./

EXPOSE 8080
CMD ["java", "org.springframework.boot.loader.JarLauncher"]
