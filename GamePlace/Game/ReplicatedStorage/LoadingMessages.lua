local LoadingMessages = {
    "Fun fact: This game have more than 20k+ lines of code!",
    "Fun fact: This game have more than 100+ scripts!",
    "Fun fact: The creators are Brazillian!",
    "Don't trust prodigy.",
}
local LastMessage = ""

function LoadingMessages:Choose()
    local Message = LoadingMessages[math.random(1, #LoadingMessages)]
    print(Message, LastMessage)
    if Message == LastMessage then
        LoadingMessages:Choose()
    end
    return Message
end

return LoadingMessages