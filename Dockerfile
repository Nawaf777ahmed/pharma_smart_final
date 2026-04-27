# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project files and restore dependencies
COPY ["PharmaSmartWeb/PharmaSmartWeb.csproj", "PharmaSmartWeb/"]
RUN dotnet restore "PharmaSmartWeb/PharmaSmartWeb.csproj"

# Copy the rest of the code
COPY . .
WORKDIR "/src/PharmaSmartWeb"
RUN dotnet build "PharmaSmartWeb.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "PharmaSmartWeb.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Final Runtime Image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

# Copy published files
COPY --from=publish /app/publish .

# Final check for permissions (optional but good for Linux environments)
RUN chmod -R 755 /app

ENTRYPOINT ["dotnet", "PharmaSmartWeb.dll"]
