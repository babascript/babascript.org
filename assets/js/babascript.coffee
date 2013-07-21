$ ->
	linda = new Linda()
	console.log linda

	ts = new linda.TupleSpace("takumibaba")

	makeCallbackId = ()->
		return new Date()-0+"_"+Math.floor(Math.random()*1000000);

	linda.io.on "connect", ->
		# ts.watch ["babascript"], (tuple)->
		# 	$("ul.reply").append "<li>#{tuple}</li>"

	$("button.do").click (e)->
		text = $("input.order").val()
		callbackId = makeCallbackId()
		tuple = ["babascript", "eval", text, [], {callback: callbackId}]
		ts.write tuple
		$("ul.reply").append "<li>you: #{text}</li>"
		takeTuple = ["babascript", "return", callbackId]
		ts.take takeTuple, (tuple)->
			console.log tuple
			text = tuple[3]
			$("ul.reply").append "<li>baba: #{text}</li>"