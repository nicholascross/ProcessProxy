# ProcessProxy

ProcessProxy is a Swift-based command proxy that allows you to define routes that execute system commands and process their output. It facilitates dynamic routing and process execution through HTTP requests with a simple and structured configuration.

## Features

- **Dynamic Command Execution**: Map HTTP routes to system commands and execute them dynamically.
- **Flexible Configuration**: Load configurations in JSON format, which permits easy adjustments to routes and commands.
- **Support for Input Processing**: Capture input from HTTP requests and forward it to command arguments and options.

## Requirements

- Swift 6.0 or higher
- macOS 13 or later

## Installation

To clone and build the project, run the following commands:

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

The application requires a JSON configuration file (`config.json`) that defines the routes and corresponding commands. When the application starts, it will look for the `config.json` file in the present working directory.

Here’s a practical example of how your `config.json` might look for a simple command that processes user inputs:

```json
{
    "routes": [
        {
            "path": "/echo",
            "command": "echo",
            "arguments": [
                {
                    "type": "constant",
                    "value": "User says:"
                },
                {
                    "type": "argument",
                    "value": ".message"
                }
            ],
            "inputMapping": ".message"
        }
    ]
}
```

### Route Configuration Fields

- **path (required)**: The HTTP path that will trigger the command.
- **command (required)**: The command to execute.
- **arguments**: An array of dynamic arguments which can be constants or mappings from the request body.
- **inputMapping**: Input mapping from the request body that will be piped into the command.

## Usage

After you have configured your routes, you can run the application:

```bash
process-proxy
```

Once the server is running, you can execute commands by making HTTP POST requests to the paths defined in your configuration. Here is an example using `curl` to send a message:

```bash
curl -X POST http://localhost:8080/echo \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello, World!"}'
```

This command will result in the server executing `echo "User says:" "Hello, World!"`.

## Notes

- The application requires `jq` to be installed on your system, as it utilizes it for JSON processing.
- This application is intended for development and testing purposes only. Be aware of the risks of exposing system commands via an API. Ensure the commands to be executed do not contain security vulnerabilities, as they will run on the server.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements or bug fixes.
