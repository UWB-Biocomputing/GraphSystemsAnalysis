"""
Render a saliency movie over many graphs.

Author: Haripriya Dhanasekaran
Year: 2025
"""

from pathlib import Path
from typing import Iterable, Optional, Sequence, List

import imageio.v2 as imageio

from plots_saliency_frame import plot_saliency_subgraph  # adjust import to your layout


def render_saliency_movie(
    graph_indices: Sequence[int],
    graphs_pt: Path,
    explain_root: Path,
    global_id_npz: Path,
    node_meta_csv: Path,
    origin_csv: Optional[Path],
    frames_dir: Path,
    movie_path: Path,
    top_pct: float = 0.20,
    category: str = "pre_burst",
    fps: int = 5,
) -> None:
    """
    Generate per-graph saliency PNG frames and stitch them into a movie.

    Parameters
    ----------
    graph_indices : sequence of int
        Graph indices to visualize (order defines movie order).
    graphs_pt, explain_root, global_id_npz, node_meta_csv, origin_csv :
        Passed through to `plot_saliency_subgraph`.
    frames_dir : Path
        Directory where individual frames (PNG) will be saved.
    movie_path : Path
        Output movie path (.mp4 recommended).
    top_pct : float
        Fraction of nodes used as salient region.
    category : str
        Explanation category ('pre_burst' or 'non_burst').
    fps : int
        Frames per second for the movie.
    """
    frames_dir = Path(frames_dir)
    movie_path = Path(movie_path)
    frames_dir.mkdir(parents=True, exist_ok=True)
    movie_path.parent.mkdir(parents=True, exist_ok=True)

    frame_paths: List[Path] = []

    for idx in graph_indices:
        frame_path = frames_dir / f"frame_{idx:05d}.png"
        frame_paths.append(
            plot_saliency_subgraph(
                graph_idx=idx,
                graphs_pt=graphs_pt,
                explain_root=explain_root,
                global_id_npz=global_id_npz,
                node_meta_csv=node_meta_csv,
                origin_csv=origin_csv,
                top_pct=top_pct,
                save_path=frame_path,
                category=category,
                show=False,
            )
        )

    # stitch into movie
    with imageio.get_writer(movie_path, fps=fps) as writer:
        for fp in frame_paths:
            img = imageio.imread(fp)
            writer.append_data(img)

    print(f"Saved saliency movie → {movie_path}")
