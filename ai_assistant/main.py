import json
from dotenv import load_dotenv
import os
from pydantic import BaseModel
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import PydanticOutputParser
from langchain.agents import create_tool_calling_agent, AgentExecutor
from tools import search_tool, wiki_tool, save_tool # Import the tool definitions

# Load environment variables (if needed, when running locally)
#if os.environ.get('AWS_EXECUTION_ENV') is None:
#    load_dotenv()
    


class ResearchResponse(BaseModel):
    topic: str
    summary: str
    sources: list[str]
    tools_used: list[str]
    

def handler(event, context):
    """
    Lambda function handler.
    """
    print("Received event:", json.dumps(event))

    # Initialize LangChain components *inside* the handler
    llm = ChatAnthropic(model="claude-3-5-sonnet-20241022")
    # llm = ChatOpenAI(model="gpt-4.1") #commented
    parser = PydanticOutputParser(pydantic_object=ResearchResponse)

    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                """
                You are a research assistant that will help generate a research paper.
                Answer the user query and use neccessary tools. 
                Wrap the output in this format and provide no other text\n{format_instructions}
                """,
            ),
            ("placeholder", "{chat_history}"),
            ("human", "{query}"),
            ("placeholder", "{agent_scratchpad}"),
        ]
    ).partial(format_instructions=parser.get_format_instructions())

    tools = [search_tool, wiki_tool, save_tool]
    agent = create_tool_calling_agent(
        llm=llm,
        prompt=prompt,
        tools=tools
    )

    agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
    

    # 1. Extract the query from the event.  Crucially, handle the 'GET' request.
    if event['httpMethod'] == 'GET':
        if 'queryStringParameters' in event and 'query' in event['queryStringParameters']:
            query = event['queryStringParameters']['query']
        else:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing "query" parameter in GET request'}),
                'headers': {'Content-Type': 'application/json'}
            }
    elif event['httpMethod'] == 'POST': #add post
        try:
            body = json.loads(event['body'])
            query = body.get('query')
            if not query:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'message': 'Missing "query" in request body'}),
                    'headers': {'Content-Type': 'application/json'}
                }
        except json.JSONDecodeError:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Invalid JSON in request body'}),
                'headers': {'Content-Type': 'application/json'}
            }
    else:
        return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Invalid HTTP method. Use GET or POST.'}),
                'headers': {'Content-Type': 'application/json'}
            }

    # 2. Invoke the agent executor.
    try:
        raw_response = agent_executor.invoke({"query": query})
        print("Raw response: ",raw_response)
        structured_response = parser.parse(raw_response.get("output")[0]["text"])
        print("Parsed response:", structured_response)
        
        # 3. Return the structured response.
        return {
            'statusCode': 200,
            'body': json.dumps(structured_response.dict()),  #  Use .dict() to serialize the Pydantic model
            'headers': {'Content-Type': 'application/json'}
        }
    except Exception as e:
        error_message = f"Error processing request: {str(e)}"
        print(error_message)
        return {
            'statusCode': 500,
            'body': json.dumps({'message': error_message}),
            'headers': {'Content-Type': 'application/json'}
        }
