FROM openjdk:17-jdk-slim

WORKDIR /app

COPY src /app/src
COPY pom.xml /app

RUN apt-get update && apt-get install -y maven
RUN mvn clean package -DskipTests

EXPOSE 8080

CMD ["java", "-jar", "target/App-1.0-SNAPSHOT.jar"]
