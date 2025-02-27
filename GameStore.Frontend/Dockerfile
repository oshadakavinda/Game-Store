# Use the official .NET 8 SDK for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /app

# Copy and restore dependencies
COPY . .
RUN dotnet restore

# Build and publish the Blazor Server app
RUN dotnet publish -c Release -o /publish

# Use the ASP.NET Core runtime for the final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app

# Copy the published app
COPY --from=build /publish .

# Expose the necessary port
EXPOSE 80

# Run the Blazor Server app
ENTRYPOINT ["dotnet", "GameStore.Frontend.dll"]
