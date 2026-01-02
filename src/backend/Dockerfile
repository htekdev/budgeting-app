FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Copy solution and project files
COPY *.sln .
COPY BudgetBuddy.API/*.csproj ./BudgetBuddy.API/
COPY BudgetBuddy.Domain/*.csproj ./BudgetBuddy.Domain/
COPY BudgetBuddy.Infrastructure/*.csproj ./BudgetBuddy.Infrastructure/
COPY BudgetBuddy.API.Tests/*.csproj ./BudgetBuddy.API.Tests/

# Restore dependencies
RUN dotnet restore

# Copy everything else
COPY . .

# Build
WORKDIR /app/BudgetBuddy.API
RUN dotnet build -c Release -o /app/build

# Publish
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 5000
ENTRYPOINT ["dotnet", "BudgetBuddy.API.dll"]
