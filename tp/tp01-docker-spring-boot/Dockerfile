# Etape unique : on part d'une image qui contient deja un JDK,
# et on y copie le .jar construit au prealable par Maven sur la machine.
#
# Prerequis : mvn clean package
FROM eclipse-temurin:21-jdk

WORKDIR /app

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /app/greeting.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/greeting.jar"]
