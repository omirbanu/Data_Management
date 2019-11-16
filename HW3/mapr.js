var map_MM, reduce_M;

map_MM= function() {
    var values =1;
    //var v1=this.genres.genres
    emit(this.year, values);
};

reduce_M = function(k, values) {

return Array.sum(values);   
};


db.full_info2.mapReduce(
    map_MM,
    reduce_M,
    { out: "map_reduce_example" });
    
//db.map_reduce_example.find()
//db.map_reduce_example.drop()
var map_MM, reduce_M;

map_MM= function() {
    var values =1;
    var v1=this.rank
    emit(v1, values);
};

reduce_M = function(k, values) {

return Array.sum(values);   
};


db.full_info2.mapReduce(
    map_MM,
    reduce_M,
    { out: "map_reduce_example" ,query:{ 'year': 2000 , 'genres.genres':'Comedy'}});

