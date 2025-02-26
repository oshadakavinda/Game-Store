using GameStore.Api.Data;
using GameStore.Api.Endpoints;

var builder = WebApplication.CreateBuilder(args);

var connString = "Data Source=GameStore.db";

builder.Services.AddSqlite<GameStoreContext>(connString);

// Build the application using the configured builder
var app = builder.Build();

// Force the app to listen on port 5274
 app.Urls.Add("http://0.0.0.0:5274");

app.MapGamesEndpoints();
app.MapGenresEndpoints();

await app.MigrateDbAsync();

// Start the web application and listen for incoming requests
app.Run();


// By default, ASP.NET Core assigns a random port. Check the terminal output when running the app—it should display something like:
// Now listening on: http://localhost:5274
