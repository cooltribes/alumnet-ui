function short_string(string,limit)
{
	if(!isNaN(limit)) 
        if (string.length > limit+3 && limit > 1)
          return string.substr(0,limit)+'...'
    return string
}