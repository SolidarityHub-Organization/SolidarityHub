# SolidarityHub

An app that eases the process of people and resource management in case of a disaster or emergency.

## Executing The App

1. Install flutter (follow the tutorial [here](https://docs.flutter.dev/get-started/install/windows/mobile))
2. Create a file called `.env.development` following the same structure as `.env.example` with the real Postgres credentials
3. Open a terminal and move to `./Backend` folder
4. Run `dotnet run`
5. Open another terminal and move to `./Desktop` folder
6. Run `flutter run`

## Development Setup

1. Install docker
2. Clone the repository
3. Run `docker-compose up` in the Backend directory
4. Postgres credentials:

-   username: admin
-   password: admin
-   database: postgres
-   host: 127.0.0.1
-   port: 5432

5. You can now access using any postgres client such as pgAdmin or DBeaver.
