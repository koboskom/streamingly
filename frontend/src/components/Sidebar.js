import React, { useContext } from 'react'
import "./Sidebar.css";
import SidebarOption from "./SidebarOption";
import HomeIcon from "@material-ui/icons/Home";
import EmojiSymbolsIcon from '@material-ui/icons/EmojiSymbols';
import LibraryMusicIcon from "@material-ui/icons/LibraryMusic";
import AlbumIcon from '@material-ui/icons/Album';
import {Link} from "react-router-dom";
import playerContext from '../context/PlayerContext'


function Sidebar() {
  const { SetCurrent, currentSong,songs, setPlayingFalse } = useContext(playerContext)

  

    return (

        <div className="sidebar">
        <div  className="sidebar__title" ><h2>Streamingly</h2></div>
        <br/>
        <Link onClick={() => { SetCurrent(0); setPlayingFalse()}} style={{ textDecoration: 'none' }} to="/"><SidebarOption Icon={HomeIcon} title="Library" /></Link>
        <Link  style={{ textDecoration: 'none' }} to="/artists"><SidebarOption Icon={LibraryMusicIcon} title="Artists" /></Link>
        <Link  style={{ textDecoration: 'none' }} to="/genre"><SidebarOption Icon={EmojiSymbolsIcon} title="Genres" /></Link>
        <Link  style={{ textDecoration: 'none' }} to="/allalbums"><SidebarOption Icon={AlbumIcon} title="Albums" /></Link>
        <br/>
        <strong className="music">Music</strong>
        <hr/>
    
          <div className="scrollbar scrollbar-secondary">
          {
            songs.map((song, i) =>
              <div className={'songContainer ' + (currentSong === i ? 'selected' : '')} key={song.id} onClick={() => { SetCurrent(i); }}>
                <SidebarOption  key = {i} title ={song.title}/>
              </div>
            )
           }
         
          </div>

      </div> 
    );
  }
  
  export default Sidebar;
