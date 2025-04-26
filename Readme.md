# Python AI Assistant Demo on AWS Lambda

This is a basic demo repository for deploying a Python-based AI assistant to AWS Lambda using container images. The assistant uses LangChain, Anthropic, and potentially other tools to generate research papers.

## Prerequisites

* **AWS Account:** You need an active AWS account.
* **AWS CLI:** The AWS Command Line Interface should be installed and configured.
* **Docker:** Docker must be installed on your local machine to build the container image.
* **Terraform:** Terraform is required to provision the AWS resources.
* **Python 3.11:** The code is written in Python 3.11.
* **Virtual Environment (Recommended):** It's recommended to use a virtual environment to manage dependencies.

## Setup Instructions

1.  **Clone the Repository:**

    ```bash
    git clone [https://github.com/superali/mlops-demo.git](https://github.com/superali/mlops-demo.git)
    cd mlops-demo>
    ```

2.  **Set up a Virtual Environment (Recommended):**

    * On Linux/macOS:

        ```bash
        python3 -m venv venv
        source venv/bin/activate
        ```

    * On Windows:

        ```bash
        venv\Scripts\activate
        ```

3.  **Install Dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

4.  **Configure AWS Credentials:**

    * Ensure your AWS CLI is configured with the necessary credentials to create resources (ECR repository, Lambda function, IAM roles, etc.). You can do this using `aws configure`.

5.  **Build the Docker Image:**

    * Navigate to the directory containing the `Dockerfile`. In most cases, this will be the root of the repository.

    ```bash
    docker build -t ai-assistant-image:latest .
    ```

    * Note: The `Dockerfile` is set up to copy your application code and dependencies into the container.

6.  **Deploy Image:**

    * The Terraform code will create an ECR repository for you.
    * You need to deploy the image to the ECR repository created by the Terraform code.
    * First, authenticate to ECR:

        ```bash
        aws ecr get-login-password --region <your-aws-region> | docker login --username AWS --password-stdin <your-ecr-repository-url>
        ```

        * Replace `<your-aws-region>` and `<your-ecr-repository-url>` with the correct values. The ECR repository URL can be found in the output of the `terraform apply` command after the repository is created.

    * Tag the Docker image:

        ```bash
        docker tag ai-assistant-image:latest <your-ecr-repository-url>:latest
        ```

    * Push the image to ECR:

        ```bash
        docker push <your-ecr-repository-url>:latest
        ```

7.  **Deploy with Terraform:**

    * Initialize Terraform:

        ```bash
        terraform init
        ```

    * Apply the Terraform configuration:

        ```bash
        terraform apply
        ```

    * This will create the necessary AWS resources, including:

        * ECR repository
        * Lambda function (using the container image you built)
        * IAM roles and policies
        * API Gateway

    * The output of `terraform apply` will display the API Gateway endpoint URL.

8.  **Invoke the API:**

    * Use the API Gateway endpoint URL from the previous step to send requests to your AI assistant. You can use `curl`, Postman, or any other HTTP client.

    * Example `curl` command (POST):

        ```bash
        curl -X POST \
          -H "Content-Type: application/json" \
          -d '{"query": "your research query"}' \
          <your-api-gateway-endpoint>/prod/assistant
        ```

        * Replace `<your-api-gateway-endpoint>` with the actual URL.

## Important Notes

* **ECR Deployment:** You **must** build the Docker image and push it to the ECR repository created by Terraform *after* running `terraform apply` for the first time. Terraform needs the image to be available in ECR when it creates the Lambda function.

* **API Gateway:** The API Gateway is configured to be public (`authorization = "NONE"`).
* **Logging:** The Lambda function logs to CloudWatch.
* **Environment Variables:** The Lambda function uses environment variables for configuration, including API keys. You will need to set the  `ANTHROPIC_API_KEY` variable in your Terraform configuration or as environment variables.
