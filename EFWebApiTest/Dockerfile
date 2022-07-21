FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["EFWebApiTest/EFWebApiTest.csproj", "EFWebApiTest/"]
COPY ["Core/Core.csproj", "Core/"]
COPY ["DAL/DAL.csproj", "DAL/"]
COPY ["BusinessApplication/BusinessApplication.csproj", "BusinessApplication/"]
RUN dotnet restore "EFWebApiTest/EFWebApiTest.csproj"
COPY . .
WORKDIR "/src/EFWebApiTest"
RUN dotnet build "EFWebApiTest.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "EFWebApiTest.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "EFWebApiTest.dll"]