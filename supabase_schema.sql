-- [File Path: /supabase_schema.sql]
-- Supabase Database Schema for Aetheris AI SaaS Platform
-- Enables clean user profiles, workspace sessions, dynamic chat history, and canvas-ready code documents.

-- 1. Enable UUID Extension if not already active
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create Profiles Table (Linked to Supabase Auth Users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. Create Workspace Sessions Table (Chat Sessions)
CREATE TABLE public.workspace_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT DEFAULT 'New Workspace Session' NOT NULL,
    model_used TEXT DEFAULT 'Aetheris Hybrid (Gemini 2.5 Pro)' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. Create Code Documents Table (Canvas Code Explorer States)
CREATE TABLE public.code_documents (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    session_id UUID REFERENCES public.workspace_sessions(id) ON DELETE CASCADE NOT NULL,
    title TEXT DEFAULT 'Untitled Document' NOT NULL,
    language TEXT DEFAULT 'javascript' NOT NULL,
    code TEXT DEFAULT '' NOT NULL,
    version INT DEFAULT 1 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 5. Create Messages Table (Chat History)
CREATE TABLE public.messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    session_id UUID REFERENCES public.workspace_sessions(id) ON DELETE CASCADE NOT NULL,
    role TEXT CHECK (role IN ('user', 'assistant', 'system')) NOT NULL,
    content TEXT NOT NULL,
    code_document_id UUID REFERENCES public.code_documents(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workspace_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.code_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies

-- Profiles Policies
CREATE POLICY "Users can view their own profiles" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profiles" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = id);

-- Workspace Sessions Policies
CREATE POLICY "Users can manage their own workspace sessions" 
    ON public.workspace_sessions FOR ALL 
    USING (auth.uid() = user_id);

-- Code Documents Policies
CREATE POLICY "Users can manage code documents in their sessions" 
    ON public.code_documents FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM public.workspace_sessions
            WHERE public.workspace_sessions.id = public.code_documents.session_id
            AND public.workspace_sessions.user_id = auth.uid()
        )
    );

-- Messages Policies
CREATE POLICY "Users can manage messages in their sessions" 
    ON public.messages FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM public.workspace_sessions
            WHERE public.workspace_sessions.id = public.messages.session_id
            AND public.workspace_sessions.user_id = auth.uid()
        )
    );

-- Trigger to automatically create a profile entry when a new user registers in Supabase auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'full_name', ''),
        COALESCE(new.raw_user_meta_data->>'avatar_url', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger to automatically update updated_at timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER update_sessions_updated_at
    BEFORE UPDATE ON public.workspace_sessions
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON public.code_documents
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();