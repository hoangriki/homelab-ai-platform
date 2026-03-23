// Paste the below into k6-ollama-test.js

import http from "k6/http";
import { sleep } from "k6";

export const options = {
  vus: 10,
  duration: "60s",
};

export default function () {

  const url = "http://ollama.ai.svc.cluster.local:11434/api/generate";

  const payload = JSON.stringify({
    model: "llama3",
    prompt: "Explain Kubernetes in simple terms",
    stream: false
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  http.post(url, payload, params);

  sleep(1);
}

//Install k6 On your benchmarking VM:

sudo apt install k6

//Verify:
k6 version

//Run the Benchmark

k6 run benchmarking/load-tests/k6-ollama-test.js

//This simulates: 

10 users
60 seconds
LLM prompt generation requests

