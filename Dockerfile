# Use a Python base image provided by AWS for Lambda
FROM public.ecr.aws/lambda/python:3.11

 
# Copy the requirements file into the container
COPY requirements.txt ${LAMBDA_TASK_ROOT}
 

# Install any dependencies your application needs
RUN pip install -r requirements.txt --no-cache-dir
COPY ai_assistant/* ${LAMBDA_TASK_ROOT}

 
CMD ["main.handler"]
