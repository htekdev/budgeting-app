FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["BudgetBuddy.Api/BudgetBuddy.Api.csproj", "BudgetBuddy.Api/"]
RUN dotnet restore "BudgetBuddy.Api/BudgetBuddy.Api.csproj"
COPY . .
WORKDIR "/src/BudgetBuddy.Api"
RUN dotnet build "BudgetBuddy.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BudgetBuddy.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 5000
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS=http://+:5000
ENTRYPOINT ["dotnet", "BudgetBuddy.Api.dll"]
