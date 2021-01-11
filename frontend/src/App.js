import React from 'react';
import './App.css';
import Player from "./components/Player"
import Body from "./components/Body"
import PlayerState from "./context/PlayerState"
import {
  BrowserRouter as Router,
  Route
} from "react-router-dom"
import Sidebar from './components/Sidebar';
import Artists from './components/Artists';
import Genre from './components/Genre';
import GenreSongs from './components/GenreSongs';
import ArtistSongs from './components/ArtistSongs';
import Albums from './components/Albums'
import AlbumSongs from './components/AlbumSongs'
import AllAlbums from './components/AllAlbums'

/*import Login from './components/Login'*/


function App() {  
  return (
 <PlayerState>
    <Router>
         
      <div className="App">
     {/*<Login/> */}
     <div className="player">
      <div className="player__body">
    <Sidebar/>
     <Player/>
    <Route exact path = "/" render = {props =>(
         <Body/>
    )}/>
    <Route exact path = "/artists" render = {props =>(
         <Artists/>
    )}/>
    <Route exact path = "/genre" render = {props =>(
         <Genre/>
    )}/>
    <Route exact path = "/albums/:name/:id" render = {props =>(
         <Albums/>
    )}/>
    <Route exact path = "/genre/:name/:id" render = {props =>(
         <GenreSongs/>
    )}/>
    <Route exact path = "/artists/:name/:id" render = {props =>(
         <ArtistSongs/>
    )}/>
    <Route exact path = "/albums/:name/:id/songs" render = {props =>(
         <AlbumSongs/>
    )}/>
    <Route exact path = "/allalbums" render = {props =>(
         <AllAlbums/>
    )}/>
    </div>
    </div>
    </div>
    
    </Router>
    </PlayerState>
  );
}

export default App;
