import sys
import time
import json
import logging
import requests
from multiprocessing import Process

def run_requests(proc_no, http_req, header):
  try:
      rsp = requests.get(http_req,headers=header)

  except Exception as e:
      if rsp.status_code >=400:
         print("Request failed", rsp.text)

######################################################################################
#                      Run the load-tests on the endpoint                            #
######################################################################################
def load_test(port, no_of_requests, logger,test_hostname):
  try:
    logger.debug("Starting load-test for login request")
    endpoint='/login'

    header_value="LoadTestID=" + job_name + ";RequestName=API"
    http_req = "http://" + test_hostname + ":" + str(port) + endpoint
    header = {'x-dynatrace-test':header_value}

    for j in range(5):
      for i in range(int(no_of_requests)):
        p = Process(target=run_requests, args=(i, http_req, header))
        p.start()
      time.sleep(1)

  except Exception as e:
    logger.critical("Encountered exception while running smoke_test", exc_info=e)

  finally:
    logger.debug("Completed load-test for login request")

######################################################################################
#                      Create load-test                                              #
######################################################################################
if __name__=="__main__":
   #Configure port on which your application is reachable
   args_passed = len(sys.argv)

   if (args_passed < 3):
     print("Please pass IP address and NodePort to the script")
     exit(1)
   else:
     cluster_ip = sys.argv[1]
     node_port = sys.argv[2]

   #Configure the number of requests you want to execute on your endpoint
                                                                                                                                                                           1,1           Top
   no_of_requests = "80000"

   #Job_name can be your load test id/name which will help you identify the load test uniquely
   job_name = "Test-case-1.1"

   #Job_log which can act as a repository later to identify more about the test-cases executed during the job execution
   log_file = "Test-case-1.1.log"
   #test_hostname would your application hosted

   #Initialize the loggin module in python
   logging.basicConfig(filename=log_file,
                                filemode='w',
                                format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                                datefmt='%H:%M:%S',
                                level=logging.DEBUG)
   logger = logging.getLogger()

   load_test(node_port, no_of_requests, logger, cluster_ip)

   logging.shutdown()
