from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import SQLModel, Field, Session, create_engine, select
from typing import List, Optional
from pydantic import BaseModel
from sqlalchemy import Column
from sqlalchemy.types import JSON
from contextlib import asynccontextmanager

class Movie(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    duration: int
    actors: List[str] = Field(sa_column=Column(JSON), default_factory=list)
    director: str
    rating_average: float = 0.0
    rating_count: int = 0

class MovieCreate(BaseModel):
    """Model for creating movies - excludes ID and rating fields"""
    name: str
    duration: int
    actors: List[str] = []
    director: str

class RatingIn(BaseModel):
    rating: float

DATABASE_URL = "sqlite:///./data/movies.db"
engine = create_engine(DATABASE_URL, echo=True)

@asynccontextmanager
async def lifespan(app: FastAPI):
    SQLModel.metadata.create_all(engine)
    yield

app = FastAPI(title="Movie Rating API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)


def get_session():
    with Session(engine) as session:
        yield session

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/movies/", response_model=List[Movie])
def get_movies(
    name: Optional[str] = None,
    session: Session = Depends(get_session),
):
    """
    Retrieve all movies, optionally filtering by name substring (case-insensitive).
    """
    statement = select(Movie)
    if name:
        statement = statement.where(Movie.name.ilike(f"%{name}%"))
    results = session.exec(statement).all()
    return results

@app.get("/movies/{movie_id}", response_model=Movie)
def get_movie(
    movie_id: int,
    session: Session = Depends(get_session),
):
    """Get a specific movie by ID."""
    movie = session.get(Movie, movie_id)
    if not movie:
        raise HTTPException(status_code=404, detail="Movie not found")
    return movie

@app.patch("/movies/{movie_id}/rating", response_model=Movie)
def rate_movie(
    movie_id: int,
    rating_in: RatingIn,
    session: Session = Depends(get_session),
):
    """
    Submit a new rating for a movie; updates the average rating.
    """
    movie = session.get(Movie, movie_id)
    if not movie:
        raise HTTPException(status_code=404, detail="Movie not found")
    
    if not 0 <= rating_in.rating <= 10:
        raise HTTPException(status_code=400, detail="Rating must be between 0 and 10")
    
    total_score = movie.rating_average * movie.rating_count
    movie.rating_count += 1
    total_score += rating_in.rating
    movie.rating_average = round(total_score / movie.rating_count, 2)

    session.add(movie)
    session.commit()
    session.refresh(movie)
    return movie

@app.post("/movies/", response_model=Movie)
def create_movie(
    movie_data: MovieCreate,
    session: Session = Depends(get_session),
):
    """Create a new movie entry. ID will be auto-generated."""
    movie = Movie(
        name=movie_data.name,
        duration=movie_data.duration,
        actors=movie_data.actors,
        director=movie_data.director,
        rating_average=0.0,
        rating_count=0
    )
    
    session.add(movie)
    session.commit()
    session.refresh(movie)
    return movie

@app.delete("/movies/{movie_id}")
def delete_movie(
    movie_id: int,
    session: Session = Depends(get_session),
):
    """Delete a movie by ID."""
    movie = session.get(Movie, movie_id)
    if not movie:
        raise HTTPException(status_code=404, detail="Movie not found")
    
    session.delete(movie)
    session.commit()
    return {"message": "Movie deleted successfully"}

@app.put("/movies/{movie_id}", response_model=Movie)
def update_movie(
    movie_id: int,
    movie_data: MovieCreate,
    session: Session = Depends(get_session),
):
    """Update a movie's basic information (preserves ratings)."""
    movie = session.get(Movie, movie_id)
    if not movie:
        raise HTTPException(status_code=404, detail="Movie not found")
    
    movie.name = movie_data.name
    movie.duration = movie_data.duration
    movie.actors = movie_data.actors
    movie.director = movie_data.director
    
    session.add(movie)
    session.commit()
    session.refresh(movie)
    return movie