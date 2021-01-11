import React, { useContext,useEffect,useState } from 'react'
import {useParams } from "react-router-dom"
import Artistlist from "./Artistlist"
import "./Albums.css"
import { Link} from "react-router-dom"
import playerContext from '../context/PlayerContext'
import axios from 'axios';


function Album() {
    const {name, id} = useParams();
    const { albums,artists, tempSongs, setAlbum, setTempSongs, setArtist, SetCurrent, setPlayingFalse} = useContext(playerContext)

  useEffect(() => {
    const fetchData = async () => {
      const result = await axios(
        "https://g17.labagh.pl/api/albums/",
      );
 
      setAlbum(result.data);
      
    };
 
    fetchData();
  },[]);

  useEffect(() => {
    const fetchData = async () => {
      const result = await axios(
        "https://g17.labagh.pl/api/artists/"+id+"/songs",
      );
 
      setTempSongs(result.data);
      
    };
 
    fetchData();
  },[]);
  useEffect(() => {
    const fetchData = async () => {
      const result = await axios(
        "https://g17.labagh.pl/api/artists/"+id,
      );
 
      setArtist(result.data);
      
    };
 
    fetchData();
  },[]);

  
      
        
    return (

        <div className="album">
        <div className="album__info">
         
          <div className="album__infoText">
            <strong>Albums</strong>
            <h2>Browse by album</h2>
            <p></p>
          </div>
        </div>
  
        <div className="album__songs">
          <div className="album__icons">
       

           
          <Link onClick={() => { SetCurrent(0); setPlayingFalse()}} to = {"/artists/"+name+"/"+ id} style={{ textDecoration: 'none' }}><Artistlist  name = {"All songs of "+ name }  img_src = {"https://g17.labagh.pl/media/"+artists[0].media}/></Link>      
        
       
            { 
          albums.map((album, i)=>{

                if(typeof tempSongs[0].album_id !== 'undefined'){
              if (tempSongs[0].album_id === album.id){
            return(
              
                <Link onClick={() => { SetCurrent(0); setPlayingFalse()}} key = {i} to = {"/albums/"+album.name+"/"+ album.id+ "/songs"} style={{ textDecoration: 'none' }}><Artistlist key = {i} name = {album.name}  img_src = {"https://g17.labagh.pl/media/"+album.media}/></Link> 
            );
           } }})}
        </div>
        </div>
      </div>
    );
  }
    
export default Album
