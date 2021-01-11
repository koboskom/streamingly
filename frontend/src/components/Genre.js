import React, {useState,useEffect,useContext } from 'react'
import Artistlist from "./Artistlist"
import "./Genre.css"
import { Link} from "react-router-dom"
import axios from 'axios';
import playerContext from '../context/PlayerContext'


function Genre() {
  const [genre, setGenre] = useState([])
  const { SetCurrent, setPlayingFalse } = useContext(playerContext)
  useEffect(() => {
    const fetchData = async () => {
      const result = await axios(
        "https://g17.labagh.pl/api/genres?limit=1000&offset=0",
      );
 
      setGenre(result.data);
      
    };
 
    fetchData();
  },[]);


  
    return (

        <div className="genre">
        <div className="genre__info">
          <div className="genre__infoText">
            <strong>Genres</strong>
            <h2>Browse by genre</h2>
            <p></p>
          </div>
        </div>
  
        <div className="genre__songs">
          <div className="genre__icons">     
           {
            genre.map((genre, i) =>
                <Link onClick={() => { SetCurrent(0); setPlayingFalse()}} key = {i} to = {"/genre/"+genre.name+"/"+ genre.id} style={{ textDecoration: 'none' }}><Artistlist key = {i} name = {genre.name}  img_src = {"https://g17.labagh.pl/media/"+genre.media}/></Link>      
            )
          }
        </div>
        </div>
      </div>
    );
  }
export default Genre
