// Add this to your ASP.NET Core Program.cs or Startup.cs

public void ConfigureServices(IServiceCollection services)
{
    // Add CORS policy for development
    services.AddCors(options =>
    {
        options.AddPolicy("DevelopmentCorsPolicy", builder =>
        {
            builder
                .AllowAnyOrigin()  // Allow all origins
                .AllowAnyMethod()  // Allow all HTTP methods
                .AllowAnyHeader()  // Allow all headers
                .SetIsOriginAllowed(origin => true) // Allow any origin
                .WithExposedHeaders("*"); // Expose all headers
        });
        
        options.AddPolicy("ProductionCorsPolicy", builder =>
        {
            builder
                .WithOrigins("https://yourdomain.com", "https://www.yourdomain.com")
                .WithMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .WithHeaders("Content-Type", "Authorization", "X-Requested-With")
                .AllowCredentials();
        });
    });
    
    // ... other services
}

public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    if (env.IsDevelopment())
    {
        app.UseCors("DevelopmentCorsPolicy");
    }
    else
    {
        app.UseCors("ProductionCorsPolicy");
    }
    
    // ... other middleware
}

// Alternative: Global CORS for development
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    if (env.IsDevelopment())
    {
        app.UseCors(policy => policy
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader());
    }
    
    // ... other middleware
}