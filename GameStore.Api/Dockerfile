# Stage 1: Build the ASP.NET Core API
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

# Copy project files and restore dependencies
COPY . .
RUN dotnet restore

# Build and publish the API
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

# Stage 2: Use ASP.NET Core runtime for running the API
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app

# Copy published files from the build stage
COPY --from=build /out .

# Expose API port
EXPOSE 5274

# Set the entry point
ENTRYPOINT ["dotnet", "GameStore.Api.dll"]
