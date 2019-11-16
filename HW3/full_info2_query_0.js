db.movies_genres.aggregate( [ { $group : { _id : "$movie_id", genres: {$push : "$genre"}} },{ $out : "M_genres" } ] )

//db.M_genres.drop()

db.movies_directors.aggregate([{
    $lookup: {
           from: "directors",
           localField: "director_id",
           foreignField: "id",
           as: "dir_nome"
         }
}, {
    $project:{
        director_id:1,
        movie_id:1,
        "dir_nome.first_name":1,
        "dir_nome.last_name":1
    }
}, {$out: "M_d_n"}])

db.M_d_n.aggregate( [ { $group : { _id : "$movie_id", d_names: {$push :{ id:"$director_id",d_name:"$dir_nome"}}} },{ $out : "M_d_n_1" } ] )

db.movies.aggregate([
    {
        $lookup: {
               from: "M_genres",
               localField: "id",
               foreignField: "_id",
               as: "genres"
             }
    },{
        $match: { "genres": { $ne: [] } }
    },
    {
        $out:"M_g_m"
    }
    ])

db.M_g_m.aggregate([{
    $lookup: {
           from: "M_d_n_1",
           localField: "id",
           foreignField: "_id",
           as: "directors_list"
         }
}, {$out:"M_d_n_gg"}])


db.actors_movs.aggregate( [ { $group : { _id :{ "movie_id":"$movie_id",
    "movie_name":"$movie_name"
},mr: {$push : {id:"$id",role:"$role", actor_l:"$last_name", actor_n:"$first_name"}}} },{$out:"M_actors_list"},
 ] ,{  allowDiskUse:true } )
 
 
 db.M_d_n_gg.aggregate([
    {
        $lookup: {
               from: "M_actors_list",
               localField: "id",
               foreignField: "_id.movie_id",
               as: "actors_list"
             }
    },
    
   {
       $project:{
           id:1,
           name:1,
           rank:1,
           year:1,
           genres:1,
           directors_list:1,
           "actors_list.mr":1
          
       }
   },{$out:"full_info2"}
    ])

db.full_info2.find()


/////////////////////////////////////////////////////
    
db.full_info2.find({ $and:[
    {$and:[{"actors_list.mr.actor_l":"Bardem"},{"actors_list.mr.actor_n":"Javier"},{"actors_list.mr.id":27522}]},
    {$and:[{"actors_list.mr.actor_l":"Cruz"},{"actors_list.mr.actor_n":"Penélope"},{"actors_list.mr.id":589713}]}]
},{
        id:1,
        name:1,
        rank:1,
        year:1,
        genres:1,
        directors_list:1
})

db.full_info2.find({
    $and:[{"directors_list.d_names.d_name.last_name":"Allen"},{"directors_list.d_names.d_name.first_name":"Woody"}
        ]
})

db.full_info2.find(
    {
        genres: {$elemMatch: {genres:["Comedy","Drama"]} }
    }
    )

//'Alec' 'Baldwin'

db.full_info2.find({$and:[
        {$and:[{"directors_list.d_names.d_name.last_name":"Allen"},{"directors_list.d_names.d_name.first_name":"Woody"}]},
        {$and:[{"actors_list.mr.actor_l":"Baldwin"},{"actors_list.mr.actor_n":"Alec"}]}
    ]
    })
//db.inventory.find( { price: { $not: { $gt: 1.99 } } } )

db.full_info2.find({rank:{$not:{$gt:5}}})

db.full_info2.find({rank:{$gt:5}})




