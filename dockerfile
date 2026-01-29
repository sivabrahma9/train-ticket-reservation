# ---------- Stage 1: Build the application ----------
FROM maven:3.9.6-eclipse-temurin-11 AS build

WORKDIR /app

# Copy pom.xml and download dependencies first (cache optimization)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src
COPY WebContent ./WebContent

# Build WAR file
RUN mvn clean package -DskipTests


# ---------- Stage 2: Run the application ----------
FROM tomcat:9.0-jdk11-temurin

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from build stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
