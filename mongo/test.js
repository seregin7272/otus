movie = {
    "title" : "Star Wars: Episode IV – A New Hope",
    "director" : "George Lucas",
    "year" : 1977
}


db.movies.updateOne({title : "Star Wars: Episode IV – A New Hope"},{$set : {reviews: []}})

db.movies.insertOne( {
    "title" : "Star Wars: Episode IV – A New Hope",
    "director" : "George Lucas",
    "year" : 1977
})
db.movies.updateOne({"title" : "Star Wars: Episode IV – A New Hope"},
     {"$push" : {"comments" :
                {"name" : "joe", "email" : "joe@example.com", "content" : "nice post."}}})