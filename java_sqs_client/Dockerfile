# Stage 1: Build the application with Maven
FROM maven:3.8.4-openjdk-17-slim AS build

# Set the working directory
WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Package the application
RUN mvn clean package -DskipTests

# Stage 2: Run the application with a minimal OpenJDK image
FROM openjdk:17-jdk-slim

# Set the working directory for the runtime environment
WORKDIR /app

# Copy the jar from the build stage
COPY --from=build /app/target/imagegenerator-0.0.1-SNAPSHOT.jar imagegenerator.jar

# Set the entry point to run the jar file
ENTRYPOINT ["java", "-jar", "imagegenerator.jar"]

# Expose port (adjust if necessary)
EXPOSE 8080
