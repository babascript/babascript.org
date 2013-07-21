exports.ensure = (req, res, next) ->
  return next() if req.isAuthenticated()
  return res.redirect '/auth/signin'