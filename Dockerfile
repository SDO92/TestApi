# Этап 1: Базовый образ для финального приложения
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Этап 2: Сборка приложения
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# копируем только sln и csproj (для кеша зависимостей)
COPY TestApi.sln ./
COPY src/TestApi.Api/TestApi.Api.csproj src/TestApi.Api/

RUN dotnet restore "TestApi.sln"

# копируем всё остальное
COPY . .

WORKDIR "/src/src/TestApi.Api"
RUN dotnet build "TestApi.Api.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Этап 3: Публикация приложения
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
WORKDIR /src/src/TestApi.Api
RUN dotnet publish "TestApi.Api.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Финальный этап: Создание образа для запуска
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TestApi.Api.dll"]
