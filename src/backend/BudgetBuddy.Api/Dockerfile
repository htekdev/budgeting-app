FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project files
COPY ["BudgetBuddy.Api/BudgetBuddy.Api.csproj", "BudgetBuddy.Api/"]
COPY ["BudgetBuddy.Application/BudgetBuddy.Application.csproj", "BudgetBuddy.Application/"]
COPY ["BudgetBuddy.Domain/BudgetBuddy.Domain.csproj", "BudgetBuddy.Domain/"]
COPY ["BudgetBuddy.Infrastructure/BudgetBuddy.Infrastructure.csproj", "BudgetBuddy.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "BudgetBuddy.Api/BudgetBuddy.Api.csproj"

# Copy source code
COPY . .

# Build
WORKDIR "/src/BudgetBuddy.Api"
RUN dotnet build "BudgetBuddy.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BudgetBuddy.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BudgetBuddy.Api.dll"]
