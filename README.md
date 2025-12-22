# the-mind-cove-app

## Running Jac Code

make sure node modules are installed:
```bash
npm install
```

To run your Jac code, use the Jac CLI:

```bash
jac serve app.jac
```

## creating enviroment
Create a `.env` file in the root directory and add your environment variables as needed. For example:

``` OPENAI_API_KEY
OPENAI_API_KEY=your_openai_api_key_here

```GOOGLE_API_KEY
GOOGLE_API_KEY=your_google_api_key_here
```

## Create env using conda or env
You can create a virtual environment using conda or venv. Here are the steps for both methods:
### Using conda:
1. Create a new conda environment:
    ```bash
    conda create -n <env_name> python=3.12
    ```
### Using uv:
1. Create a new virtual environment:
    ```bash
    python -m venv <env_name>
    ```


Happy coding with Jac!
