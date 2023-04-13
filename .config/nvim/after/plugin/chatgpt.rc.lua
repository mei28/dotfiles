local status, chatgpt = pcall(require, 'chatgpt')
if not status then return end


local cfg = {
  openai_params = {
    model = "gpt-3.5-turbo",
    frequency_penalty = 0,
    presence_penalty = 0,
    max_tokens = 300,
    temperature = 0,
    top_p = 1,
    n = 1,
  },
}

chatgpt.setup({cfg})
