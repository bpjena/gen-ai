FROM python:3.11-slim AS base

ARG USERNAME="genai"
ARG GROUP="genai"
ARG USERID="10002"
ARG GROUPID="10002"

RUN groupadd --gid $GROUPID $GROUP \
    && useradd --create-home --no-user-group --gid $GROUPID --uid $USERID $USERNAME


ENV HOME=/home/$USERNAME
ENV MODEL_ENGINE "generate-text-20230722"

WORKDIR /app
COPY pyproject.toml poetry.lock /app/


# install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
# RUN pip install poetry
ENV PATH $PATH:$HOME/.poetry/bin:$HOME/.local/bin
ENV PYTHONPATH $PYTHONPATH:$HOME/.local/lib/python3.10/site-packages

# Configure poetry to not use virtual environments
RUN poetry config virtualenvs.create false

# Install python dependencies
RUN poetry install --only main --no-root

COPY . /app
# Now that we've copied our project we can install it
RUN poetry install --only main

RUN chown -R $USERNAME.$GROUP $HOME /app

USER $USERNAME

FROM base as test
USER $USERNAME