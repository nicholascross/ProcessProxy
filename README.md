# ProcessProxy

ProcessProxy is a Swift-based command proxy that allows you to define routes that execute system commands and process their output.

ProcessProxy utilizes structured configuration and provides a way to handle dynamic routing and process execution through HTTP requests.

## Features

- **Dynamic Command Execution**: Map HTTP routes to system commands and execute them.
- **Flexible Configuration**: Load configurations from a JSON file, allowing for easy adjustments to routes and commands.
- **Support for Input Processing**: Capture input from HTTP requests and foward to command arguments and options.

## Requirements

- Swift 6.0 or higher
- macOS 13 or later

## Installation

To clone and build the project, run the following commands:

To install Promptly, execute the following steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/nicholascross/ProcessProxy
   cd ProcessProxy
   ```

2. Build using Swift Package Manager:
   ```bash
   swift build -c release
   ```

3. Copy the executable to your PATH:
   ```bash
   cp .build/release/process-proxy ~/bin/process-proxy
   ```

## Configuration

The application requires a JSON configuration file (`config.json`) that defines the routes and corresponding commands.

When the application starts it will look for the config.json file in the present working directory.

Here’s a basic example of how your `config.json` might look:

```json
{
    "routes": [
        {
            "path": "/execute",
            "command": "cat",
            "argumentMappings": [],
            "optionMappings": {},
            "arguments": [],
            "inputMapping": ".message"
        }
    ]
}
```

### Route Configuration Fields

- **path (required)**: The HTTP path that will trigger the command.
- **command (required)**: The command to execute.
- **argumentMappings**: An array of dynamic arguments mapped from the request body.
- **optionMappings**: A dictionary of dynamic options mapped from the request body.
- **arguments**: Static arguments to pass to the command.
- **inputMapping**: Input mapping from the request body that will be piped into the command.

## Usage

After you have configured your routes, you can run the application:

```bash
process-proxy
```

Once the server is running, you can execute commands by making HTTP POST requests to the paths defined in your configuration. An example command can be executed using `curl`:

```bash
curl -X POST http://localhost:8080/execute \                                                                                         ✔   341s 
     -H "Content-Type: application/json" \
     -d '{"message": "The sky is green"}'
```

## Notes

- The application requires `jq` to be installed on your system, as it utilizes it for JSON processing.
- This is **intended for experimentation only** be aware of the risks of exposing system commands via an API. Ensure the commands to be executed do not contain security vulnerabilities as this application will run them on the server.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements or bug fixes.
