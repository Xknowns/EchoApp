FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

COPY echo-api/target/echo-api-0.1.0.jar app.jar
COPY init.sql /app/init.sql

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]