import React, { useContext, useEffect } from 'react'
import {useParams } from "react-router-dom"
import Songlist from "./Songlist"
import playerContext from '../context/PlayerContext'
import axios from 'axios'

function ArtistSongs() {
    const {name, id} = useParams();
    const { SetCurrent, currentSong,albums, songs, setSongs } = useContext(playerContext)
    
    
    

    useEffect(() => {
      const fetchData = async () => {
        const result = await axios(
          "https://g17.labagh.pl/api/artists/"+id+"/songs?limit=1000&offset=0",
        );
   
        setSongs(result.data);
        
      };
      fetchData();
    },[]);

    
    
    
    return (
        <div className="body">
        <div className="body__info">
         
          <div className="body__infoText">
            <h2>Artist: {name}</h2>
            
          </div>
        </div>
  
        <div className="body__songs">
          <div className="body__icons">
          </div>
          
      

        { 
          songs.map((song, i)=>{
            
              
            
              const albumtIneed = albums.find(
                (album) => album.id === song.album_id
                
                )
             if (typeof song.artists !== 'undefined' && typeof song.genres !== 'undefined'){ 
              const newArtist = song.artists.toString().replace(/[0-9]/g, '').replace(',',' ');
                const newGenre = song.genres.toString().replace(/[0-9]/g, '').replace(',',' ').replace(',,',' ').replace(',,',' ');
             
              if (typeof albumtIneed !== 'undefined'){
            return(
              
                <div className={'songContainer ' + (currentSong === i ? 'selected1' : '')} key={song.id} onClick={() => { SetCurrent(i); }}>
                        
                        <Songlist key ={i} title ={song.title} artist = {newArtist} genre = {newGenre} img_src = {"https://g17.labagh.pl/media/"+albumtIneed.media}/>
                      </div>
            );
           } }}) }
        </div>
      </div>
    );
  }

export default ArtistSongs
